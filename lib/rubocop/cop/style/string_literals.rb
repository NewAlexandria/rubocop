# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # Checks if uses of quotes match the configured preference.
      class StringLiterals < Cop
        include ConfigurableEnforcedStyle
        include StringHelp

        def on_dstr(node)
          # A dstr node with dstr and str children is a concatenated
          # string. Don't ignore the whole thing.
          return if node.children.find { |child| child.type == :str }

          # Dynamic strings can not use single quotes, and quotes inside
          # interpolation expressions are checked by the
          # StringLiteralsInInterpolation cop, so ignore.
          ignore_node(node)
        end

        private

        def message(*)
          if style == :single_quotes
            "Prefer single-quoted strings when you don't need string " \
            'interpolation or special symbols.'
          else
            'Prefer double-quoted strings unless you need single quotes to ' \
            'avoid extra backslashes for escaping.'
          end
        end

        def offense?(node)
          src = node.loc.expression.source
          return false if src.start_with?('%') || src.start_with?('?')
          if style == :single_quotes
            src !~ /'/ && src !~ StringHelp::ESCAPED_CHAR_REGEXP
          else
            src !~ /" | \\/x
          end
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
            replacement = node.loc.begin.is?('"') ? "'" : '"'
            corrector.replace(node.loc.begin, replacement)
            corrector.replace(node.loc.end, replacement)
          end
        end
      end
    end
  end
end
