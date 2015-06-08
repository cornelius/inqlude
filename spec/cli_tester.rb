require "cheetah"

class CommandResult
  attr_accessor :stdout, :stderr, :exit_code
end

def run_command(args: nil)
  cmd = ["bin/inqlude"]
  result = CommandResult.new
  result.exit_code = 0
  if args
    cmd += args
  end
  begin
    o, e = Cheetah.run(cmd, stdout: :capture, stderr: :capture )
    result.stdout = o
    result.stderr = e
  rescue Cheetah::ExecutionFailed => e
    result.exit_code = e.status.exitstatus
    result.stdout = e.stdout
    result.stderr = e.stderr
  end
  result
end
