"use strict";

const MONITOR_ISSUE_TITLE = "Technology updates require wiki review";
const MONITOR_ISSUE_MARKER = "<!-- technology-update-monitor -->";

function parseReportCounts(report) {
  const text = String(report || "");
  const updates = Number((text.match(/Updates found:\s*(\d+)/) || [])[1] || 0);
  const failures = Number((text.match(/Check failures:\s*(\d+)/) || [])[1] || 0);
  return { updates, failures };
}

function findMonitorIssue(issues) {
  return (issues || []).find((issue) =>
    issue.title === MONITOR_ISSUE_TITLE &&
    typeof issue.body === "string" &&
    issue.body.includes(MONITOR_ISSUE_MARKER)
  );
}

function decideIssueAction({ updates, failures, issue }) {
  if (updates === 0 && failures === 0) {
    return issue ? "close" : "noop";
  }

  return issue ? "update" : "create";
}

function workflowRunUrl(context) {
  return `${context.serverUrl}/${context.repo.owner}/${context.repo.repo}/actions/runs/${context.runId}`;
}

function buildIssueBody(report, context) {
  return `${MONITOR_ISSUE_MARKER}
# Technology updates require wiki review

The scheduled technology monitor found items that need human review.

${report}

## Required action

- Review the changed technologies against official documentation.
- Update affected wiki pages and front matter dates.
- Record major findings in \`lessons-learned\`, \`case-studies/successes\`, or \`case-studies/failures\`.

Workflow run: ${workflowRunUrl(context)}
`;
}

async function handleTechnologyUpdateIssue({ github, context, core, report }) {
  const { updates, failures } = parseReportCounts(report);
  const { owner, repo } = context.repo;
  const existing = await github.rest.issues.listForRepo({
    owner,
    repo,
    state: "open",
    per_page: 100
  });
  const issue = findMonitorIssue(existing.data);
  const action = decideIssueAction({ updates, failures, issue });

  if (action === "noop") {
    core.info("No technology updates or check failures found. No issue needed.");
    return { action };
  }

  if (action === "close") {
    const runUrl = workflowRunUrl(context);
    await github.rest.issues.createComment({
      owner,
      repo,
      issue_number: issue.number,
      body: `Technology update monitor is clean in workflow run: ${runUrl}`
    });
    await github.rest.issues.update({
      owner,
      repo,
      issue_number: issue.number,
      state: "closed",
      state_reason: "completed"
    });
    core.info(`Closed issue #${issue.number}`);
    return { action, issueNumber: issue.number };
  }

  const body = buildIssueBody(report, context);
  if (action === "update") {
    await github.rest.issues.update({
      owner,
      repo,
      issue_number: issue.number,
      body
    });
    core.info(`Updated issue #${issue.number}`);
    return { action, issueNumber: issue.number };
  }

  const created = await github.rest.issues.create({
    owner,
    repo,
    title: MONITOR_ISSUE_TITLE,
    body
  });
  core.info(`Created issue #${created.data.number}`);
  return { action, issueNumber: created.data.number };
}

module.exports = {
  MONITOR_ISSUE_MARKER,
  MONITOR_ISSUE_TITLE,
  buildIssueBody,
  decideIssueAction,
  findMonitorIssue,
  handleTechnologyUpdateIssue,
  parseReportCounts
};
