defmodule PipelinexTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  ###########################
  # Test Pipelines
  ###########################

  defmodule SimpleMath do
    use Pipelinex

    task "add 5", num do
      num + 5
    end

    task "add 10", num do
      num + 10
    end
  end

  defmodule SimpleMathTwo do
    use Pipelinex

    pipeline SimpleMath
  end

  defmodule ExtendedMath do
    use Pipelinex

    task "add 20", num do
      num + 20
    end

    pipeline SimpleMath

    task "divide by 10", num do
      num / 10
    end
  end

  defmodule PatternMatch do
    use Pipelinex

    task "add 5", %{:value => val} = map do
      Map.put map, :value, val + 5
    end

    task "add 5", map do
      Map.put map, :value, (Map.get(map, :value) + 5)
    end
  end

  defmodule NoPatternMatch do
    use Pipelinex

    task "add 5", %{:value => val} = map do
      Map.put map, :value, val + 5
    end

    task "add 10", %{:value => val} = map do
      Map.put map, :value, val + 10
    end

    task "add 5", map do
      Map.put map, :value, (Map.get(map, :value) + 5)
    end
  end

  defmodule SamePipelineOverAndOver do
    use Pipelinex

    pipeline SimpleMath
    pipeline SimpleMath
    pipeline SimpleMath
  end

  defmodule SamePipelineOverAndOverTwo do
    use Pipelinex

    pipeline SimpleMath

    task "do nothing", data, do: data

    pipeline SimpleMath

    task "do nothing 2", data, do: data

    pipeline SimpleMath
  end

  ###########################
  # Tests
  ###########################

  @tag :capture_log
  test "it executes defined tasks" do
    result = SimpleMath.run(5)
    assert result == 20
  end

  @tag :capture_log
  test "it executes defined pipelines" do
    result = SimpleMathTwo.run(5)
    assert result == 20
  end

  @tag :capture_log
  test "it executes tasks and pipelines in the order they were defined" do
    # Since we divide in the pipeline, the result would be different
    # if the tasks and pipelines don't execute in the defined order.
    result = ExtendedMath.run(5)
    assert result == 4
  end

  @tag :capture_log
  test "multiple task definitions of the same task one after another get reduced to one task call" do
    result = PatternMatch.run(%{:value => 0})
    assert result == %{:value => 5}
  end

  @tag :capture_log
  test "multiple task definitions of the same task with other tasks/pipelines in between get executed" do
    result = NoPatternMatch.run(%{:value => 0})
    assert result == %{:value => 20}
  end

  @tag :capture_log
  test "multiple pipeline definitions of the same pipeline one after another get reduced to one pipeline call" do
    result = SamePipelineOverAndOver.run(5)
    assert result == 20
  end

  @tag :capture_log
  test "multiple pipeline definitions of the same pipeline with other tasks/pipelines in between get executed" do
    result = SamePipelineOverAndOverTwo.run(5)
    assert result == 50
  end

  test "it logs when a task starts and ends" do
    fun = fn ->  SimpleMath.run(0) end
    log = capture_log(fun)

    assert log =~ "Start: add 5"
    assert log =~ "End: add 5"

    assert log =~ "Start: add 10"
    assert log =~ "End: add 10"
  end
end
