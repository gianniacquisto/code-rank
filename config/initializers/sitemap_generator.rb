# frozen_string_literal: true

require "sitemap_generator"

# TODO: Consider making SITE_HOST configurable via ENV or credentials
# if the deployment domain changes (e.g. RPi, staging, etc.)
SitemapGenerator::Sitemap.default_host = "https://code-rank.com"
SitemapGenerator::Sitemap.sitemaps_host = "https://code-rank.com"
SitemapGenerator::Sitemap.sitemaps_path = "sitemap/"
SitemapGenerator::Sitemap.include_root = false
SitemapGenerator::Sitemap.compress = false
