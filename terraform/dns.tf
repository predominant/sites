variable "digitalocean_nameservers" {
  type = "list"
  default = [
    "ns1.digitalocean.com.",
    "ns2.digitalocean.com.",
    "ns3.digitalocean.com.",
  ]
}

variable "google_mx_servers" {
  type = "list"
  default = [
    [10, "aspmx.l.google.com."],
    [20, "alt1.aspmx.l.google.com."],
    [20, "alt2.aspmx.l.google.com."],
    [30, "aspmx2.googlemail.com."],
    [30, "aspmx3.googlemail.com."],
    [30, "aspmx4.googlemail.com."],
    [30, "aspmx5.googlemail.com."],
  ]
}

resource "digitalocean_domain" "grahamweldon_com" {
  name = "grahamweldon.com"
  ip_address = "${digitalocean_droplet.web0.ipv4_address}"
}

# NS Records
resource "digitalocean_record" "ns" {
  count = "${length(var.digitalocean_nameservers)}"
  domain = "${digitalocean_domain.grahamweldon_com.name}"
  type = "NS"
  name = "@"
  value = "${element(var.digitalocean_nameservers, count.index)}"
  ttl = 1800
}

# MX Records
resource "digitalocean_record" "mx" {
  count = "${length(var.google_mx_servers)}"
  domain = "${digitalocean_domain.grahamweldon_com.name}"
  type     = "MX"
  name     = "@"
  priority = "${element(var.google_mx_servers[count.index], 0)}"
  value    = "${element(var.google_mx_servers[count.index], 1)}"
  ttl      = 7200
}

# A Records
resource "digitalocean_record" "a" {
  domain = "${digitalocean_domain.grahamweldon_com.name}"
  type = "A"
  name = "@"
  value = "${digitalocean_droplet.web0.ipv4_address}"
  ttl = 1800
}

# CNAME Records
resource "digitalocean_record" "cname_domains" {
  domain = "${digitalocean_domain.grahamweldon_com.name}"
  type = "CNAME"
  name = "domains"
  value = "my.domainnameshop.com.au."
  ttl = 7200
}

resource "digitalocean_record" "cname_dev" {
  domain = "${digitalocean_domain.grahamweldon_com.name}"
  type = "CNAME"
  name = "dev"
  value = "grahamweldon.com."
  ttl = 7200
}

resource "digitalocean_record" "cname_wild" {
  domain = "${digitalocean_domain.grahamweldon_com.name}"
  type = "CNAME"
  name = "*"
  value = "grahamweldon.com."
  ttl = 7200
}
