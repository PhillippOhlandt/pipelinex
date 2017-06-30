# Pipelinex

Pipelinex is a simple library to build data pipelines in a clean and structured way.

It's mainly built for personal usage to help with structuring big data processing flows
and automatically apply things like logging, which otherwise would make the code very unclean.

## Installation

The package can be installed by adding `pipelinex` 
to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:pipelinex, "~> 0.1.0"}]
end
```

## Usage

Pipelinex provides two macros to build pipelines, `task` and `pipeline`.

### Simple Example

Build simple pipelines using the `task` macro:

```elixir
defmodule MyPipeline do
  use Pipelinex

  task "add 5", num do
    num + 5
  end

  task "add 10", num do
    num + 10
  end
end
```

Execute the pipeline via it's injected `run/1` function:

```elixir
result = MyPipeline.run(5)
result == 20
```

### Reference Other Pipelines

Pipelines can execute other pipelines using the `pipeline` macro:

```elixir
defmodule MyOtherPipeline do
  use Pipelinex

  pipeline MyPipeline

  task "add 20", num do
    num + 20
  end
end

result = MyOtherPipeline.run(5)
result == 40
```

### Pattern Matching

The `task` macro supports pattern matching for its data argument.

```elixir
defmodule MyPipeline do
  use Pipelinex

  task "add 5", %{:value => val} = map do
    Map.put map, :value, val + 5
  end

  task "add 10", %{:value => val} = map do
    Map.put map, :value, val + 10
  end
end
```

If two or more tasks with the same name are defined one after another,
the task will be called once and normal pattern matching behaviour will be applied.

```elixir
defmodule MyPipeline do
  use Pipelinex

  task "add 5", %{:value => val} = map do
    Map.put map, :value, val + 5
  end

  task "add 5", num do
    num + 5
  end
end

value = MyPipeline.run(%{:value => 5})
value == %{value: 10}

value = MyPipeline.run(5)
value == 10
```

### Logging

Pipelinex logs when a task starts and ends using `Logger.info`

```elixir
defmodule MyPipeline do
  use Pipelinex

  task "add 5", num do
    num + 5
  end

  task "add 10", num do
    num + 10
  end
end

MyPipeline.run(5)
# 20
#
# 13:27:43.870 [info]  Start: add 5
#
# 13:27:43.870 [info]  End: add 5
#
# 13:27:43.870 [info]  Start: add 10
#
# 13:27:43.870 [info]  End: add 10
```
