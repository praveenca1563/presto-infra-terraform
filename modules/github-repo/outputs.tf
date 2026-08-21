output "repository_full_name" {
  value = data.github_repository.this.full_name
}

output "repository_html_url" {
  value = data.github_repository.this.html_url
}

output "repository_ssh_clone_url" {
  value = data.github_repository.this.ssh_clone_url
}

output "node_id" {
  value = data.github_repository.this.node_id
}