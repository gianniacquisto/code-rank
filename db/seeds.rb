# Populates the database with real open-source technologies.
# Safe to run multiple times — uses find_or_create_by for idempotency.
# Usage: bin/rails db:seed

TECHNOLOGIES = [
  # Frameworks
  { name: "rails", github_url: "https://github.com/rails/rails" },
  { name: "django", github_url: "https://github.com/django/django" },
  { name: "fastapi", github_url: "https://github.com/fastapi/fastapi" },
  { name: "express", github_url: "https://github.com/expressjs/express" },
  { name: "next", github_url: "https://github.com/vercel/next.js" },
  { name: "spring-boot", github_url: "https://github.com/spring-projects/spring-boot" },
  { name: "laravel", github_url: "https://github.com/laravel/laravel" },
  { name: "flask", github_url: "https://github.com/pallets/flask" },
  { name: "react", github_url: "https://github.com/facebook/react" },
  { name: "vue", github_url: "https://github.com/vuejs/core" },

  # Languages & Runtimes
  { name: "typescript", github_url: "https://github.com/microsoft/TypeScript" },
  { name: "python", github_url: "https://github.com/python/cpython" },
  { name: "rust", github_url: "https://github.com/rust-lang/rust" },
  { name: "go", github_url: "https://github.com/golang/go" },
  { name: "node", github_url: "https://github.com/nodejs/node" },
  { name: "deno", github_url: "https://github.com/denoland/deno" },
  { name: "bun", github_url: "https://github.com/oven-sh/bun" },

  # Databases
  { name: "postgresql", github_url: "https://github.com/postgres/postgres" },
  { name: "sqlite", github_url: "https://github.com/sqlite/sqlite" },
  { name: "redis", github_url: "https://github.com/redis/redis" },
  { name: "mongodb", github_url: "https://github.com/mongodb/mongo" },
  { name: "mysql", github_url: "https://github.com/mysql/mysql-server" },

  # DevOps & Infrastructure
  { name: "docker", github_url: "https://github.com/moby/moby" },
  { name: "kubernetes", github_url: "https://github.com/kubernetes/kubernetes" },
  { name: "terraform", github_url: "https://github.com/hashicorp/terraform" },
  { name: "nginx", github_url: "https://github.com/nginx/nginx" },
  { name: "traefik", github_url: "https://github.com/traefik/traefik" },

  # CI/CD & Monitoring
  { name: "github-actions", github_url: "https://github.com/actions/runner" },
  { name: "jenkins", github_url: "https://github.com/jenkinsci/jenkins" },
  { name: "grafana", github_url: "https://github.com/grafana/grafana" },
  { name: "prometheus", github_url: "https://github.com/prometheus/prometheus" },

  # Tooling & Linters
  { name: "pre-commit", github_url: "https://github.com/pre-commit/pre-commit" },
  { name: "black", github_url: "https://github.com/psf/black" },
  { name: "eslint", github_url: "https://github.com/eslint/eslint" },
  { name: "prettier", github_url: "https://github.com/prettier/prettier" },
  { name: "tailwindcss", github_url: "https://github.com/tailwindlabs/tailwindcss" },
  { name: "vite", github_url: "https://github.com/vitejs/vite" },
  { name: "webpack", github_url: "https://github.com/webpack/webpack" },
  { name: "bundler", github_url: "https://github.com/rubygems/bundler" },

  # Testing
  { name: "pytest", github_url: "https://github.com/pytest-dev/pytest" },
  { name: "jest", github_url: "https://github.com/jestjs/jest" },
  { name: "rspec", github_url: "https://github.com/rspec/rspec-rails" },
  { name: "cypress", github_url: "https://github.com/cypress-io/cypress" },
  { name: "playwright", github_url: "https://github.com/microsoft/playwright" }
]

TECHNOLOGIES.each do |tech|
  Technology.find_or_create_by!(name: tech[:name]) do |t|
    t.github_url = tech[:github_url]
  end
end

puts "Seeded #{TECHNOLOGIES.size} technologies."
