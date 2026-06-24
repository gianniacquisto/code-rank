# frozen_string_literal: true

class SitemapRefreshJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "Regenerating sitemap..."
    require "sitemap_generator"
    SitemapGenerator::Interpreter.run(config_file: Rails.root + "config/sitemap.rb")
    SitemapGenerator::Sitemap.finalize!
    Rails.logger.info "Sitemap regenerated successfully"
  rescue => e
    Rails.logger.error "Sitemap regeneration failed: #{e.message}"
    raise
  end
end
