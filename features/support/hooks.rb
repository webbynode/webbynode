Before do
  @orig_stdout = $stdout
  $stdout = StringIO.new
end

After do
  $stdout = @orig_stdout
end
