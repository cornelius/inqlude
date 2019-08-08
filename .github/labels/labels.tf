terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "cornelius"

    workspaces {
      name = "inqlude-labels"
    }
  }
}

variable "github_token" {}

provider "github" {
  organization = "cornelius"
  token = "${var.github_token}"
}

resource "github_issue_label" "cornelius_inqlude_bug" {
  repository  = "inqlude"
  name        = "Bug"
  description = "Issue in existing functionality"
  color       = "000080"
}

resource "github_issue_label" "cornelius_inqlude_feature" {
  repository  = "inqlude"
  name        = "Feature"
  description = "New functionality"
  color       = "1034A6"
}

resource "github_issue_label" "cornelius_inqlude_refactoring" {
  repository  = "inqlude"
  name        = "Refactoring"
  description = "Improvement of code without user-visible changes"
  color       = "0F52BA"
}

resource "github_issue_label" "cornelius_inqlude_cli" {
  repository  = "inqlude"
  name        = "CLI"
  description = "Command Line Interface"
  color       = "228B22"
}

resource "github_issue_label" "cornelius_inqlude_data" {
  repository  = "inqlude"
  name        = "Data"
  description = "Inqlude data, including schema and content"
  color       = "2E8B57"
}

resource "github_issue_label" "cornelius_inqlude_documentation" {
  repository  = "inqlude"
  name        = "Documentation"
  description = ""
  color       = "3CB371"
}

resource "github_issue_label" "cornelius_inqlude_web_site" {
  repository  = "inqlude"
  name        = "Web Site"
  description = "Inqlude web site"
  color       = "66CDAA"
}

resource "github_issue_label" "cornelius_inqlude_low" {
  repository  = "inqlude"
  name        = "Low Priority"
  description = ""
  color       = "fbca04"
}

resource "github_issue_label" "cornelius_inqlude_medium" {
  repository  = "inqlude"
  name        = "Medium Priority"
  description = ""
  color       = "eb6420"
}

resource "github_issue_label" "cornelius_inqlude_high" {
  repository  = "inqlude"
  name        = "High Priority"
  description = ""
  color       = "e11d21"
}

resource "github_issue_label" "cornelius_inqlude_first_issue" {
  repository  = "inqlude"
  name        = "good first issue"
  description = "good issue to start with if you are new to the project"
  color       = "5319e7"
}

resource "github_issue_label" "cornelius_inqlude_gsoc" {
  repository  = "inqlude"
  name        = "GSoC"
  description = "possible task or project for GSoC"
  color       = "5319e7"
}

resource "github_issue_label" "cornelius_inqlude-data_new_data" {
  repository  = "inqlude-data"
  name        = "New Data"
  description = "New manifests"
  color       = "3382fe"
}

resource "github_issue_label" "cornelius_inqlude-data_update_data" {
  repository  = "inqlude-data"
  name        = "Update Data"
  description = "Update manifests"
  color       = "65a1fe"
}

resource "github_issue_label" "cornelius_inqlude-data_format" {
  repository  = "inqlude-data"
  name        = "Format"
  description = "Manifest Format"
  color       = "98c0fe"
}

resource "github_issue_label" "cornelius_inqlude-data_first_issue" {
  repository  = "inqlude-data"
  name        = "good first issue"
  description = "good issue to start with if you are new to the project"
  color       = "5319e7"
}

resource "github_issue_label" "cornelius_inqlude-data_gsoc" {
  repository  = "inqlude-data"
  name        = "GSoC"
  description = "possible task or project for GSoC"
  color       = "5319e7"
}
