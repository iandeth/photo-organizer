require 'optparse'
require_relative 'lib/photo_organizer'

opt = ARGV.getopts('', 'from:./test', 'to:')
PhotoOrganizer.new(in_dir:opt["from"], out_dir:opt["to"]).run
