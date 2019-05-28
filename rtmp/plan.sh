pkg_name=site-rtmp
pkg_origin=grahamweldon
pkg_version="2019.05.28.0"
pkg_maintainer="Graham Weldon <graham@grahamweldon.com>"
pkg_license=("Apache-2.0")
pkg_description="Nginx based RTMP Relay Service"
nginx_version=1.16.0
rtmp_version=1.2.1
rtmp_dirname="nginx-rtmp-module-${rtmp_version}"
rtmp_shasum=87aa597400b0b5a05274ee2d23d8cb8224e12686227a0abe31d783b3a645ea37
pkg_dirname="nginx-${nginx_version}"
pkg_source="https://nginx.org/download/${pkg_dirname}.tar.gz"
pkg_upstream_url=https://grahamweldon.com
pkg_shasum=4fd376bad78797e7f18094a00f0f1088259326436b537eb5af69b01be2ca1345
pkg_deps=(
  core/glibc
  core/libedit
  core/ncurses
  core/zlib
  core/bzip2
  core/openssl
  core/pcre
)
pkg_build_deps=(
  core/gcc
  core/make
  core/coreutils
)
pkg_lib_dirs=(lib)
pkg_bin_dirs=(sbin)
pkg_include_dirs=(include)
pkg_svc_run="nginx -c ${pkg_svc_config_path}/nginx.conf"
pkg_svc_user="root"
pkg_exposes=(port)
pkg_exports=(
  [port]=rtmp.server.port
)
pkg_exposes=(port)

do_download() {
  do_default_download
  download_file "https://github.com/arut/nginx-rtmp-module/archive/v${rtmp_version}.tar.gz" "nginx-rtmp-module-${rtmp_version}.tar.gz"
  verify_file "nginx-rtmp-module-${rtmp_version}.tar.gz" "${rtmp_shasum}"
  unpack_file "nginx-rtmp-module-${rtmp_version}.tar.gz"
}

do_build() {
  ./configure --prefix="${pkg_prefix}" \
    --conf-path="${pkg_svc_config_path}/nginx.conf" \
    --sbin-path="${pkg_prefix}/bin/nginx" \
    --pid-path="${pkg_svc_var_path}/nginx.pid" \
    --lock-path="${pkg_svc_var_path}/nginx.lock" \
    --user=hab \
    --group=hab \
    --http-log-path=/dev/stdout \
    --error-log-path=stderr \
    --http-client-body-temp-path="${pkg_svc_var_path}/client-body" \
    --http-proxy-temp-path="${pkg_svc_var_path}/proxy" \
    --http-fastcgi-temp-path="${pkg_svc_var_path}/fastcgi" \
    --http-scgi-temp-path="${pkg_svc_var_path}/scgi" \
    --http-uwsgi-temp-path="${pkg_svc_var_path}/uwsgi" \
    --with-ipv6 \
    --with-pcre \
    --with-pcre-jit \
    --with-file-aio \
    --with-stream=dynamic \
    --with-stream_ssl_module \
    --with-mail=dynamic \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_realip_module \
    --with-http_v2_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_addition_module \
    --with-http_degradation_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_secure_link_module \
    --with-http_sub_module \
    --with-http_slice_module \
    --with-cc-opt="${CFLAGS}" \
    --with-ld-opt="${LDFLAGS}" \
    --add-module="${HAB_CACHE_SRC_PATH}/${rtmp_dirname}"

  make
}

do_install() {
  make install
  mkdir -p "${pkg_prefix}/sbin"
  cp "${HAB_CACHE_SRC_PATH}/${pkg_dirname}/objs/nginx" "${pkg_prefix}/sbin"
  cp "${HAB_CACHE_SRC_PATH}/${rtmp_dirname}/stat.xsl" "${pkg_prefix}/html"
}
