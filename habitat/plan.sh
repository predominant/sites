pkg_name=grahamweldon-website
pkg_origin=grahamweldon
pkg_version="0.1.0"
pkg_maintainer="Graham Weldon <graham@grahamweldon.com>"
pkg_license=("Apache-2.0")
pkg_description="Personal website of Graham Weldon"
pkg_upstream_url="https://grahamweldon.com"
pkg_deps=(
  core/coreutils
  core/caddy
)
pkg_build_deps=(
  core/hugo
  core/node
)
pkg_svc_run="caddy -conf ${pkg_svc_config_path}/Caddyfile"
pkg_exports=(
  [http-port]=http.port
  [https-port]=https.port
)
pkg_exposes=(http-port https-port)

do_build() {
  local theme_name=$(hugo config | grep 'theme = ' | awk -F'"' '{print $2}')
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
