defmodule LiveEmailNotification.Helpers.Converter do
  def convert!("true"), do: true
  def convert!("false"), do: false
  def convert!(num), do: String.to_integer(num)
end