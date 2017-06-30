defmodule Pipelinex do
  @moduledoc """
  Pipelinex provides macros to build simple data pipelines that
  can execute tasks and other pipelines in a defined order.

  ## Simple Example

  Build simple pipelines using the `task` macro:

      defmodule MyPipeline do
        use Pipelinex

        task "add 5", num do
          num + 5
        end

        task "add 10", num do
          num + 10
        end
      end

  Execute the pipeline via it's injected `run/1` function:

      result = MyPipeline.run(5)
      result == 20

  ## Reference Other Pipelines

  Pipelines can execute other pipelines using the `pipeline` macro:

      defmodule MyOtherPipeline do
        use Pipelinex

        pipeline MyPipeline

        task "add 20", num do
          num + 20
        end
      end

      result = MyOtherPipeline.run(5)
      result == 40

  ## Pattern Matching

  The `task` macro supports pattern matching for its data argument.

      defmodule MyPipeline do
        use Pipelinex

        task "add 5", %{:value => val} = map do
          Map.put map, :value, val + 5
        end

        task "add 10", %{:value => val} = map do
          Map.put map, :value, val + 10
        end
      end

  If two or more tasks with the same name are defined one after another,
  the task will be called once and normal pattern matching behaviour will be applied.

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

  ## Logging

  Pipelinex logs when a task starts and ends using `Logger.info`

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

  """
  defmacro __using__(_options) do
    quote do
      Module.register_attribute __MODULE__, :steps, accumulate: true

      require Logger
      import unquote(__MODULE__), only: [task: 3, pipeline: 1]
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(env) do
    steps =  Module.get_attribute(env.module, :steps) |> Enum.reverse |> Enum.dedup

    func_calls = Enum.map steps, fn step ->
      case step do
        {:task, func, _} ->
          quote do
            val = unquote(func)(val)
          end
        {:pipeline, module, _} ->
          quote do
            val = unquote(module).run(val)
          end
      end
    end

    quote do
      def run(val) do
        unquote_splicing(func_calls)
        val
      end
    end
  end

  defmacro task(name, var, do: inner) do
    func_name = String.to_atom(name)

    do_block = quote do
      Logger.info "Start: #{unquote(name)}"
      result = unquote(inner)
      Logger.info "End: #{unquote(name)}"
      result
    end

    quote do
      @steps {:task, unquote(func_name), unquote(name)}
      def unquote(func_name)(unquote(var)), do: unquote(do_block)
    end
  end

  defmacro pipeline(module) do
    quote do
      @steps {:pipeline, unquote(module), ""}
    end
  end
end
