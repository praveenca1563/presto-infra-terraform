output "repository_full_name" {
  value = github_repository.this.full_name
}

output "repository_html_url" {
  value = github_repository.this.html_url
}

output "repository_ssh_clone_url" {
  value = github_repository.this.ssh_clone_url
}

output "node_id" {
  value = github_repository.this.node_id
}
