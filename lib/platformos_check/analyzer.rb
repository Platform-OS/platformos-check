# frozen_string_literal: true

module PlatformosCheck
  class Analyzer
    def initialize(platformos_app, checks = Check.all.map(&:new), auto_correct = false)
      @platformos_app = platformos_app
      @auto_correct = auto_correct

      @liquid_checks = Checks.new
      @yaml_checks = Checks.new
      @html_checks = Checks.new

      checks.each do |check|
        check.platformos_app = @platformos_app

        case check
        when LiquidCheck
          @liquid_checks << check
        when YamlCheck
          @yaml_checks << check
        when HtmlCheck
          @html_checks << check
        end
      end
    end

    def offenses
      @liquid_checks.flat_map(&:offenses) +
        @yaml_checks.flat_map(&:offenses) +
        @html_checks.flat_map(&:offenses)
    end

    def yaml_file_count
      @yaml_file_count ||= @platformos_app.yaml.size
    end

    def liquid_file_count
      @liquid_file_count ||= @platformos_app.liquid.size
    end

    def total_file_count
      yaml_file_count + liquid_file_count
    end

    # Returns all offenses for all files in platformos_app
    def analyze_platformos_app
      reset

      liquid_visitor = LiquidVisitor.new(@liquid_checks, @disabled_checks)
      html_visitor = HtmlVisitor.new(@html_checks)

      PlatformosCheck.with_liquid_c_disabled do
        @platformos_app.liquid.each_with_index do |liquid_file, i|
          yield(liquid_file.relative_path.to_s, i, total_file_count) if block_given?
          liquid_visitor.visit_liquid_file(liquid_file)
          html_visitor.visit_liquid_file(liquid_file)
        end
      end

      @platformos_app.yaml.each_with_index do |yaml_file, i|
        yield(yaml_file.relative_path.to_s, liquid_file_count + i, total_file_count) if block_given?
        @yaml_checks.call(:on_file, yaml_file)
      end

      finish(false)

      offenses
    end

    # When only_single_file is false:
    #   Runs single file checks for each file in `files`
    #   Runs whole platformos_app checks
    #   Returns single file checks offenses for file in `files` + whole platformos_app checks
    # When only_single_file is true:
    #   Runs single file checks for each file in `files`
    #   Does not run whole platformos_app checks
    #   Returns single file checks offenses for file in `files`
    # When files is empty and only_single_file is false:
    #   Only returns whole platformos_app checks
    # When files is empty and only_single_file is true:
    #   Returns empty array
    def analyze_files(files, only_single_file: false)
      reset

      PlatformosCheck.with_liquid_c_disabled do
        total = files.size
        offset = 0

        unless only_single_file
          # Call all checks that run on the whole platformos_app
          liquid_visitor = LiquidVisitor.new(@liquid_checks.whole_platformos_app, @disabled_checks)
          html_visitor = HtmlVisitor.new(@html_checks.whole_platformos_app)
          total += total_file_count
          offset = total_file_count
          @platformos_app.liquid.each_with_index do |liquid_file, i|
            yield(liquid_file.relative_path.to_s, i, total) if block_given?
            liquid_visitor.visit_liquid_file(liquid_file)
            html_visitor.visit_liquid_file(liquid_file)
          end

          @platformos_app.yaml.each_with_index do |yaml_file, i|
            yield(yaml_file.relative_path.to_s, liquid_file_count + i, total) if block_given?
            @yaml_checks.whole_platformos_app.call(:on_file, yaml_file)
          end
        end

        # Call checks that run on a single files, only on specified file
        liquid_visitor = LiquidVisitor.new(@liquid_checks.single_file, @disabled_checks, only_single_file:)
        html_visitor = HtmlVisitor.new(@html_checks.single_file)
        files.each_with_index do |app_file, i|
          yield(app_file.relative_path.to_s, offset + i, total) if block_given?
          if app_file.liquid?
            liquid_visitor.visit_liquid_file(app_file)
            html_visitor.visit_liquid_file(app_file)
          elsif app_file.yaml?
            @yaml_checks.single_file.call(:on_file, app_file)
          end
        end
      end

      finish(only_single_file)

      offenses
    end

    def uncorrectable_offenses
      return offenses unless @auto_correct

      offenses.select { |offense| !offense.correctable? }
    end

    def correct_offenses
      return unless @auto_correct

      offenses.each(&:correct)
    end

    def write_corrections
      return unless @auto_correct

      @platformos_app.liquid.each(&:write)
    end

    private

    def reset
      @disabled_checks = DisabledChecks.new

      @liquid_checks.each do |check|
        check.offenses.clear
      end

      @html_checks.each do |check|
        check.offenses.clear
      end

      @yaml_checks.each do |check|
        check.offenses.clear
      end
    end

    def finish(only_single_file = false)
      if only_single_file
        @liquid_checks.single_file.call(:on_end)
        @html_checks.single_file.call(:on_end)
        @yaml_checks.single_file.call(:on_end)
      else
        @liquid_checks.call(:on_end)
        @html_checks.call(:on_end)
        @yaml_checks.call(:on_end)
      end

      @disabled_checks.remove_disabled_offenses(@liquid_checks)
      @disabled_checks.remove_disabled_offenses(@yaml_checks)
      @disabled_checks.remove_disabled_offenses(@html_checks)
    end
  end
end
