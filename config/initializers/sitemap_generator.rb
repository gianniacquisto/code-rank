# frozen_string_literal: true

require "sitemap_generator"

SitemapGenerator::Sitemap.default_host = ENV.fetch("SITE_HOST", "https://code-rank.com")
SitemapGenerator::Sitemap.sitemaps_host = ENV.fetch("SITE_HOST", "https://code-rank.com")
SitemapGenerator::Sitemap.sitemaps_path = "sitemap/"
SitemapGenerator::Sitemap.include_root = false
