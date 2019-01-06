variable "github_token" {}

provider "github" {
  organization = "cornelius"
  token = "${var.github_token}"
}

resource "github_issue_label" "1181821042a" {
  repository  = "inqlude"
  name        = "Bug"
  description = "Issue in existing functionality"
  color       = "000080"
}

resource "github_issue_label" "1181821042b" {
  repository  = "inqlude"
  name        = "Feature"
  description = "New functionality"
  color       = "1034A6"
}

resource "github_issue_label" "1181821042" {
  repository  = "inqlude"
  name        = "Refactoring"
  description = "Improvement of code without user-visible changes"
  color       = "0F52BA"
}

resource "github_issue_label" "1181821630" {
  repository  = "inqlude"
  name        = "CLI"
  description = "Command Line Interface"
  color       = "228B22"
}

resource "github_issue_label" "1181823572" {
  repository  = "inqlude"
  name        = "Data"
  description = "Inqlude data, including schema and content"
  color       = "2E8B57"
}

resource "github_issue_label" "1181820759" {
  repository  = "inqlude"
  name        = "Documentation"
  description = ""
  color       = "3CB371"
}

resource "github_issue_label" "60095012" {
  repository  = "inqlude"
  name        = "Web Site"
  description = "Inqlude web site"
  color       = "66CDAA"
}

resource "github_issue_label" "120813816" {
  repository  = "inqlude"
  name        = "Low Priority"
  description = ""
  color       = "fbca04"
}

resource "github_issue_label" "120813794" {
  repository  = "inqlude"
  name        = "Medium Priority"
  description = ""
  color       = "eb6420"
}

resource "github_issue_label" "120813779" {
  repository  = "inqlude"
  name        = "High Priority"
  description = ""
  color       = "e11d21"
}

resource "github_issue_label" "761165516" {
  repository  = "inqlude"
  name        = "good first issue"
  description = "good issue to start with if you are new to the project"
  color       = "5319e7"
}

resource "github_issue_label" "395340299" {
  repository  = "inqlude"
  name        = "GSoC"
  description = "possible task or project for GSoC"
  color       = "5319e7"
}
