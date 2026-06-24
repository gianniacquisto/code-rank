# frozen_string_literal: true

require "technology"

# Root page
SitemapGenerator::Sitemap.add root_path, priority: 1.0, changefreq: "daily"

# Technology pages with lastmod from updated_at
Technology.find_each do |technology|
  SitemapGenerator::Sitemap.add technology_path(technology),
    lastmod: technology.updated_at,
    priority: 0.8,
    changefreq: "weekly"
end
