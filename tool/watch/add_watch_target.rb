#!/usr/bin/env ruby
# Adds the watchOS companion target ("WatchApp") to ios/Runner.xcodeproj and
# embeds it in Runner, then keeps its files in sync with ios/WatchApp/:
# every *.swift is a source, Assets.xcassets and the <lang>.lproj/Localizable.strings
# are resources. Idempotent: run it again after adding files to ios/WatchApp.
#
# Uses the `xcodeproj` gem that ships with CocoaPods:
#   ruby tool/watch/add_watch_target.rb
require 'xcodeproj'

ROOT = File.expand_path('../..', __dir__)
PROJECT_PATH = File.join(ROOT, 'ios', 'Runner.xcodeproj')
WATCH_DIR = File.join(ROOT, 'ios', 'WatchApp')
TEAM = 'HK5V7DF66Q'
WATCH_BUNDLE_ID = 'com.artlab.moodcalendar.watchkitapp'
COMPANION_BUNDLE_ID = 'com.artlab.moodcalendar'
WATCHOS_TARGET = '9.0'
LANGUAGES = %w[en es de fr it].freeze

project = Xcodeproj::Project.open(PROJECT_PATH)
runner = project.targets.find { |t| t.name == 'Runner' }
watch = project.targets.find { |t| t.name == 'WatchApp' }
created = watch.nil?

if created
  watch = project.new_target(:application, 'WatchApp', :watchos, WATCHOS_TARGET, nil, :swift, 'WatchApp')
  project.main_group.new_group('WatchApp', 'WatchApp').new_file('WatchApp.xcconfig')
  xcconfig = project.main_group['WatchApp']['WatchApp.xcconfig']

  watch.build_configurations.each do |config|
    config.base_configuration_reference = xcconfig
    s = config.build_settings
    s['SDKROOT'] = 'watchos'
    # Without these Xcode builds the watch app with the iPhone SDK in an archive.
    s['SUPPORTED_PLATFORMS'] = 'watchos watchsimulator'
    s['SUPPORTS_MACCATALYST'] = 'NO'
    s['TARGETED_DEVICE_FAMILY'] = '4'
    s['WATCHOS_DEPLOYMENT_TARGET'] = WATCHOS_TARGET
    s['SWIFT_VERSION'] = '5.0'
    s['PRODUCT_BUNDLE_IDENTIFIER'] = WATCH_BUNDLE_ID
    s['PRODUCT_NAME'] = '$(TARGET_NAME)'
    s['GENERATE_INFOPLIST_FILE'] = 'YES'
    s['INFOPLIST_KEY_CFBundleDisplayName'] = 'Mood Calendar'
    s['INFOPLIST_KEY_WKApplication'] = 'YES'
    s['INFOPLIST_KEY_WKCompanionAppBundleIdentifier'] = COMPANION_BUNDLE_ID
    s['MARKETING_VERSION'] = '$(FLUTTER_BUILD_NAME)'
    s['CURRENT_PROJECT_VERSION'] = '$(FLUTTER_BUILD_NUMBER)'
    s['ASSETCATALOG_COMPILER_APPICON_NAME'] = 'AppIcon'
    s['DEVELOPMENT_TEAM'] = TEAM
    s['CODE_SIGN_STYLE'] = 'Automatic'
    s['SKIP_INSTALL'] = 'YES'
    s['LD_RUNPATH_SEARCH_PATHS'] = ['$(inherited)', '@executable_path/Frameworks']
    s['SWIFT_EMIT_LOC_STRINGS'] = 'YES'
  end

  runner.add_dependency(watch)
  embed = runner.new_copy_files_build_phase('Embed Watch Content')
  embed.dst_subfolder_spec = '16'
  embed.dst_path = '$(CONTENTS_FOLDER_PATH)/Watch'
  build_file = embed.add_file_reference(watch.product_reference, true)
  build_file.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }

  # The embed phase has to sit before Flutter's "Thin Binary" script, or Xcode
  # reports a dependency cycle.
  runner.build_phases.delete(embed)
  thin = runner.build_phases.index { |p| p.respond_to?(:name) && p.name == 'Thin Binary' }
  runner.build_phases.insert(thin, embed)

  project.root_object.attributes['TargetAttributes'][watch.uuid] = { 'CreatedOnToolsVersion' => '15.0' }
end

group = project.main_group['WatchApp']

# Sources: every Swift file in ios/WatchApp.
referenced = watch.source_build_phase.files.map { |f| f.file_ref&.path }.compact
Dir[File.join(WATCH_DIR, '*.swift')].sort.each do |path|
  name = File.basename(path)
  next if referenced.include?(name)
  watch.source_build_phase.add_file_reference(group.new_file(name))
  puts "Added source #{name}"
end

# Resources: the asset catalog and the localized strings.
resource_paths = watch.resources_build_phase.files.map { |f| f.file_ref&.display_name }.compact
unless resource_paths.include?('Assets.xcassets')
  watch.resources_build_phase.add_file_reference(group.new_file('Assets.xcassets'))
  puts 'Added Assets.xcassets'
end

unless resource_paths.include?('Localizable.strings')
  variant = group.new_variant_group('Localizable.strings')
  LANGUAGES.each do |lang|
    next unless File.exist?(File.join(WATCH_DIR, "#{lang}.lproj", 'Localizable.strings'))
    variant.new_file("#{lang}.lproj/Localizable.strings")
  end
  watch.resources_build_phase.add_file_reference(variant)
  puts 'Added Localizable.strings'
end

regions = project.root_object.known_regions
LANGUAGES.each { |lang| regions << lang unless regions.include?(lang) }
project.root_object.known_regions = regions

project.save
puts created ? "Added WatchApp (#{WATCH_BUNDLE_ID}) and embedded it in Runner." : 'WatchApp already existed; files synced.'
