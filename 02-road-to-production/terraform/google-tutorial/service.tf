# enable the iam service
resource "google_project_service" "iam_service" {
  service = "iam.googleapis.com"
}

# enable the container service
resource "google_project_service" "container_service" {
  service = "container.googleapis.com"
}