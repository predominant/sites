pkg_name=site-grahamweldon
pkg_origin=grahamweldon
pkg_version="1.0.5"
pkg_maintainer="Graham Weldon <graham@grahamweldon.com>"
pkg_license=("Apache-2.0")
pkg_description="Personal website of Graham Weldon"
pkg_upstream_url="https://grahamweldon.com"
pkg_deps=(
  core/caddy
  core/coreutils
  core/cacerts
)
pkg_build_deps=(
  rakops/hugo
  core/node
  core/tar
)
pkg_svc_run="caddy -conf ${pkg_svc_config_path}/Caddyfile"
pkg_exports=(
  [http-port]=http.port
  [https-port]=https.port
)
pkg_exposes=(http-port https-port)

app_prefix="${HAB_CACHE_SRC_PATH}/${pkg_name}-${pkg_version}"

do_build() {
  mkdir -pv "${app_prefix}"
  build_line "Copying site to prepare for build"
  find . | _tar_pipe_app_cp_to "${app_prefix}"

  local theme_name=$(hugo config | grep 'theme = ' | awk -F'"' '{print $2}')
  # Build theme assets
  build_line "Building theme assets"
  pushd "${app_prefix}" > /dev/null
  pushd "themes/${theme_name}" > /dev/null
  npm install
  fix_interpreter "node_modules/.bin/*" core/coreutils bin/env
  npm run-script build
  popd > /dev/null

  # Build site
  build_line "Building static site"
  hugo \
    --ignoreCache \
    --verbose
  popd > /dev/null
}

do_install() {
  pushd "${app_prefix}" > /dev/null
  cp -r public "${pkg_prefix}/"
  popd > /dev/null
}

_tar_pipe_app_cp_to() {
  local dst_path tar
  dst_path="$1"
  tar="$(pkg_path_for tar)/bin/tar"

  "$tar" -cp \
      --owner=root:0 \
      --group=root:0 \
      --no-xattrs \
      --exclude-backups \
      --exclude-vcs \
      --exclude='habitat' \
      --exclude='results' \
      --exclude='node_modules' \
      --exclude='public' \
      --files-from=- \
      -f - \
  | "$tar" -x \
      -C "$dst_path" \
      -f -
}
