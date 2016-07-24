# Use @javascript and `DRIVER=selenium --format pretty` for the full experience
AfterStep '@single_step' do
  single_step
end

if ENV["SINGLE_STEP"]
  AfterStep do
    single_step
  end
end

def single_step
  print "Single stepping. Hit enter to continue."
  STDIN.getc
end
