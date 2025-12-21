defmodule Pictible.Utils do
  def is_dev do
    Mix.env() == :dev
  end
end
