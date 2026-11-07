#!/usr/bin/env ruby
# Registers ios/Runner/<lang>.lproj/InfoPlist.strings (Face ID usage text) as a
# localized variant group in the Runner target. Idempotent.
#   ruby tool/ios_add_infoplist_strings.rb
require 'xcodeproj'

ROOT = File.expand_path('..', __dir__)
project = Xcodeproj::Project.open(File.join(ROOT, 'ios', 'Runner.xcodeproj'))
runner = project.targets.find { |t| t.name == 'Runner' }
group = project.main_group['Runner']

variant = group.children.find { |c| c.display_name == 'InfoPlist.strings' }
variant ||= group.new_variant_group('InfoPlist.strings')
%w[en es de fr it].each do |lang|
  next if variant.children.any? { |c| c.display_name == lang }
  variant.new_reference("#{lang}.lproj/InfoPlist.strings")
end
unless runner.resources_build_phase.files_references.include?(variant)
  runner.resources_build_phase.add_file_reference(variant)
end
project.save
