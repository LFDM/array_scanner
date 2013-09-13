# ArrayScanner
[![Build Status](https://travis-ci.org/LFDM/array_scanner.png)](https://travis-ci.org/LFDM/array_scanner)
[![Coverage Status](https://coveralls.io/repos/LFDM/array_scanner/badge.png)](https://coveralls.io/r/LFDM/array_scanner)
[![Dependency Status](https://gemnasium.com/LFDM/array_scanner.png)](https://gemnasium.com/LFDM/array_scanner)


Class for traversing an array, remembering the position of a pointer and
recent scan operations, very much like Ruby's standard library
StringScanner.

## Installation

Add this line to your application's Gemfile:

    gem 'array_scanner'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install array_scanner

## Example Usage

    ArrayScanner.new([:a,      :b,      :c,      :d,      :e,      :f,      :g])

                 inspect => "Pointer at 0/6. Current element: :a"

                 forward(2) => 2
                       o-------2-------> *

                 current_element => :c
                                         *
                 
                 scan { |el| el == :c } => :c
                                         o---1--> *

                 position => 3
                                                  *

                 rest => [:d, :e, :f, :g]
                                                  *

                 rest_size => 4
                                                  *

                 scan_until { |el| el == :f } => [:d, :e]
                                                  o-------2-------> *
                 
                 unscan => 3
                                                  * <-------2-------o                  

                 scan_until(true) { |el| el == :f } => [:d, :e, :f]
                                                  o------------3-----------> *

                 eoa? => true
                                                                             *

                 rewind_to { |el| el == :b } => :b
                               * <--------------------5--------------------- *

                 surroundings => [:a, :c]
                               *

                 last_positions => [6, 3, 5, 3, 2, 0]
                               *

                 last_results => [[:d, :e, :f], [:d, :e], :c]
                               *
                                        
                 Check tests for more behaviour.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
