# frozen_string_literal: true

class SitemapRefreshJob < ApplicationJob
  queue_as :default

  def perform
    require "sitemap_generator"
    SitemapGenerator::Interpreter.run(config_file: Rails.root + "config/sitemap.rb")
    SitemapGenerator::Sitemap.finalize!
  end
end
