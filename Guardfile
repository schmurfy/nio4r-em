
guard 'bacon', :output => "BetterOutput", :backtrace => nil do
  watch(%r{^lib/nio4r-em/(.+)\.rb$})     { |m| "specs/unit/#{m[1]}_spec.rb" }
  watch(%r{specs/.+\.rb$})
end

