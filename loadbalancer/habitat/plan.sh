pkg_name=site-loadbalancer
pkg_origin=grahamweldon
pkg_version="2022.02.04.3"
pkg_maintainer="Graham Weldon <graham@grahamweldon.com>"
pkg_license=("Apache-2.0")
pkg_description="Front load balancer for all my sites"
pkg_deps=(
  grahamweldon/caddy
)
pkg_svc_run="caddy run -config ${pkg_svc_config_path}/Caddyfile"
pkg_exports=(
  [http-port]=http.port
  [https-port]=https.port
)
pkg_exposes=(http-port https-port)
pkg_binds=(
  [grahamweldon]="http-port"
  [rustymothertruckers]="http-port"
)

# Require root for port < 1024 binding.
pkg_svc_user="root"
pkg_svc_group="${pkg_svc_user}"

do_build() {
  return 0
}

do_install() {
  return 0
}
