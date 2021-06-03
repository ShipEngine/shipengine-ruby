# rubocop:disable

# frozen_string_literal: true
# === EDITOR ===
Pry.editor = "vi"

# === COLORS ===
unless ENV["PRY_BW"]
  Pry.color = true
  Pry.config.theme = "railscasts"
end

# === Listing config ===
# Better colors - by default the headings for methods are too
# similar to method name colors leading to a "soup"
# These colors are optimized for use with Solarized scheme
# for your terminal
Pry.config.ls.separator = "\n" # new lines between methods
Pry.config.ls.heading_color = :magenta
Pry.config.ls.public_method_color = :green
Pry.config.ls.protected_method_color = :yellow
Pry.config.ls.private_method_color = :bright_black

# == PLUGINS ===
# awesome_print gem: great syntax colorized printing
# look at ~/.aprc for more settings for awesome_print
begin
  require "awesome_print"
  # The following line enables awesome_print for all pry output,
  # and it also enables paging
  Pry.config.print = proc { |output, value| Pry::Helpers::BaseHelpers.stagger_output("=> #{value.ai}", output) }

  # If you want awesome_print without automatic pagination, use the line below
  module AwesomePrint
    Formatter.prepend(Module.new do
      def awesome_self(object, type)
        if type == :string && @options[:string_limit] && object.inspect.to_s.length > @options[:string_limit]
          colorize(object.inspect.to_s[0..@options[:string_limit]] + "...", type)
        else
          super(object, type)
        end
      end
    end)
  end

  AwesomePrint.defaults = {
    string_limit: 80,
    indent: 2,
    multiline: true,
  }
  AwesomePrint.pry!
rescue LoadError => err
  puts "gem install awesome_print  # <-- highly recommended"
end

# rubocop:enable
