
# Copyright (c) 2026 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  grafana_common_dashboard_dir = "${path.module}/files/grafana/dashboards/common"
  grafana_amd_dashboard_dir    = "${path.module}/files/grafana/dashboards/amd"
  grafana_nvidia_dashboard_dir = "${path.module}/files/grafana/dashboards/nvidia"
  grafana_oci_dashboard_dir    = "${path.module}/files/grafana/dashboards/oci"

  grafana_common_dashboard_files = fileset("${local.grafana_common_dashboard_dir}", "*.json")
  grafana_amd_dashboard_files    = fileset("${local.grafana_amd_dashboard_dir}", "*.json")
  grafana_nvidia_dashboard_files = fileset("${local.grafana_nvidia_dashboard_dir}", "*.json")
  grafana_oci_dashboard_files    = fileset("${local.grafana_oci_dashboard_dir}", "*.json")

  grafana_common_dashboard_files_path = (var.install_monitoring && var.install_grafana && var.install_grafana_dashboards) ? [for f in local.grafana_common_dashboard_files : join("/", ["${local.grafana_common_dashboard_dir}", f])] : []
  grafana_amd_dashboard_files_path    = (var.install_monitoring && var.install_grafana && var.install_grafana_dashboards) ? [for f in local.grafana_amd_dashboard_files : join("/", ["${local.grafana_amd_dashboard_dir}", f])] : []
  grafana_nvidia_dashboard_files_path = (var.install_monitoring && var.install_grafana && var.install_grafana_dashboards) ? [for f in local.grafana_nvidia_dashboard_files : join("/", ["${local.grafana_nvidia_dashboard_dir}", f])] : []
  grafana_oci_dashboard_files_path    = (var.install_monitoring && var.install_grafana && var.install_grafana_dashboards && var.setup_oci_metrics_exporter) ? [for f in local.grafana_oci_dashboard_files : join("/", ["${local.grafana_oci_dashboard_dir}", f])] : []

  grafana_common_dashboards = (var.install_monitoring && var.install_grafana && var.install_grafana_dashboards) ? {
    for f in local.grafana_common_dashboard_files :
    f => file(join("/", ["${local.grafana_common_dashboard_dir}", f]))
  } : {}
  grafana_amd_dashboards = (var.install_monitoring && var.install_grafana && var.install_grafana_dashboards) ? {
    for f in local.grafana_amd_dashboard_files :
    f => file(join("/", ["${local.grafana_amd_dashboard_dir}", f]))
  } : {}
  grafana_nvidia_dashboards = (var.install_monitoring && var.install_grafana && var.install_grafana_dashboards) ? {
    for f in local.grafana_nvidia_dashboard_files :
    f => file(join("/", ["${local.grafana_nvidia_dashboard_dir}", f]))
  } : {}
  grafana_oci_dashboards = (var.install_monitoring && var.install_grafana && var.install_grafana_dashboards && var.setup_oci_metrics_exporter) ? {
    for f in local.grafana_oci_dashboard_files :
    f => file(join("/", ["${local.grafana_oci_dashboard_dir}", f]))
  } : {}

  grafana_alert_dir   = "${path.module}/files/grafana/alerts"
  grafana_alert_files = fileset(local.grafana_alert_dir, "*.yaml")
  grafana_alerts = (var.install_monitoring && var.install_grafana && var.install_grafana_dashboards) ? {
    for f in local.grafana_alert_files :
    f => file(join("/", [local.grafana_alert_dir, f]))
  } : {}

  grafana_alert_files_path = (var.install_monitoring && var.install_grafana && var.install_grafana_dashboards) ? [for f in local.grafana_alert_files : join("/", ["${local.grafana_alert_dir}", f])] : []

  grafana_admin_password_enabled = alltrue([var.install_monitoring, var.install_node_problem_detector_kube_prometheus_stack])
  grafana_admin_password         = one(random_password.grafana_admin_password[*].result)
}

moved {
  from = random_password.grafana_admin_password
  to   = random_password.grafana_admin_password[0]
}

resource "random_password" "grafana_admin_password" {
  count = local.grafana_admin_password_enabled ? 1 : 0

  length           = 16
  min_lower        = 1
  min_upper        = 1
  min_numeric      = 1
  min_special      = 1
  override_special = "!#$%&*()-_=+[]:?"
}
