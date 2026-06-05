"use strict";

const assert = require("node:assert/strict");
const test = require("node:test");
const {
  MONITOR_ISSUE_MARKER,
  MONITOR_ISSUE_TITLE,
  decideIssueAction,
  handleTechnologyUpdateIssue,
  parseReportCounts
} = require("../../tools/technology-update-issue.js");

function createHarness(existingIssues = []) {
  const calls = [];
  const github = {
    rest: {
      issues: {
        listForRepo: async (params) => {
          calls.push(["listForRepo", params]);
          return { data: existingIssues };
        },
        create: async (params) => {
          calls.push(["create", params]);
          return { data: { number: 77 } };
        },
        update: async (params) => {
          calls.push(["update", params]);
          return { data: { number: params.issue_number } };
        },
        createComment: async (params) => {
          calls.push(["createComment", params]);
          return { data: { id: 10 } };
        }
      }
    }
  };
  const info = [];
  const core = { info: (message) => info.push(message) };
  const context = {
    serverUrl: "https://github.com",
    runId: 12345,
    repo: { owner: "dozo83576-beep", repo: "llm-dev-wiki" }
  };

  return { calls, context, core, github, info };
}

function monitorIssue(number = 12) {
  return {
    number,
    title: MONITOR_ISSUE_TITLE,
    body: `${MONITOR_ISSUE_MARKER}\nold body`
  };
}

test("parseReportCounts returns zero for missing counters", () => {
  assert.deepEqual(parseReportCounts("# Technology update report"), {
    updates: 0,
    failures: 0
  });
});

test("decideIssueAction maps clean and dirty states", () => {
  assert.equal(decideIssueAction({ updates: 0, failures: 0, issue: undefined }), "noop");
  assert.equal(decideIssueAction({ updates: 0, failures: 0, issue: monitorIssue() }), "close");
  assert.equal(decideIssueAction({ updates: 1, failures: 0, issue: undefined }), "create");
  assert.equal(decideIssueAction({ updates: 0, failures: 1, issue: monitorIssue() }), "update");
});

test("dirty report without existing issue creates monitor issue", async () => {
  const harness = createHarness();
  const result = await handleTechnologyUpdateIssue({
    ...harness,
    report: "- Updates found: 2\n- Check failures: 0"
  });

  assert.equal(result.action, "create");
  const createCall = harness.calls.find(([name]) => name === "create");
  assert.ok(createCall);
  assert.equal(createCall[1].title, MONITOR_ISSUE_TITLE);
  assert.match(createCall[1].body, /Updates found: 2/);
});

test("dirty report with existing issue updates body", async () => {
  const harness = createHarness([monitorIssue(20)]);
  const result = await handleTechnologyUpdateIssue({
    ...harness,
    report: "- Updates found: 0\n- Check failures: 1"
  });

  assert.equal(result.action, "update");
  const updateCall = harness.calls.find(([name]) => name === "update");
  assert.ok(updateCall);
  assert.equal(updateCall[1].issue_number, 20);
  assert.match(updateCall[1].body, /Check failures: 1/);
});

test("clean report with existing issue comments and closes as completed", async () => {
  const harness = createHarness([monitorIssue(31)]);
  const result = await handleTechnologyUpdateIssue({
    ...harness,
    report: "- Updates found: 0\n- Check failures: 0"
  });

  assert.equal(result.action, "close");
  const commentCall = harness.calls.find(([name]) => name === "createComment");
  const updateCall = harness.calls.find(([name]) => name === "update");
  assert.equal(commentCall[1].issue_number, 31);
  assert.match(commentCall[1].body, /actions\/runs\/12345/);
  assert.equal(updateCall[1].state, "closed");
  assert.equal(updateCall[1].state_reason, "completed");
});

test("clean report without existing issue does not mutate GitHub issues", async () => {
  const harness = createHarness();
  const result = await handleTechnologyUpdateIssue({
    ...harness,
    report: "- Updates found: 0\n- Check failures: 0"
  });

  assert.equal(result.action, "noop");
  assert.deepEqual(
    harness.calls.map(([name]) => name),
    ["listForRepo"]
  );
  assert.match(harness.info.join("\n"), /No technology updates/);
});
