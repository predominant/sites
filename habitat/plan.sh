pkg_name=grahamweldon-website
pkg_origin=predominant
pkg_version="0.1.0"
pkg_maintainer="Graham Weldon <graham@grahamweldon.com>"
pkg_license=("Apache-2.0")
pkg_description="Personal website of Graham Weldon"
pkg_upstream_url="https://grahamweldon.com"
pkg_deps=(
  core/coreutils
  core/nginx
)
pkg_build_deps=(
  core/hugo
  core/node
)
pkg_svc_run="nginx -c ${pkg_svc_config_path}/nginx.conf"
pkg_exports=(
  [port]=srv.port
  [ssl-port]=srv.ssl.port
)
pkg_exposes=(port ssl-port)

do_build() {
  local theme_name=$(hugo config | grep 'theme = ' | awk -F'"' '{print $2}')
  attach
  # Build theme assets
  build_line "Building theme assets"
  pushd "themes/${theme_name}" > /dev/null
  npm install
  fix_interpreter "node_modules/.bin/*" core/coreutils bin/env
  npm run-script build
  popd

  # Build site
  build_line "Building static site"
  hugo
}

do_install() {
  cp -r public "${pkg_prefix}/"
}
