defmodule RiotApiClient.Api do
  @moduledoc """
  Common functions while interacting with APIs
  """
  @spec handle_response({:ok, Req.Response.t()} | {:error, Exception.t()}) ::
          {:ok, any()} | {:error, String.t()}
  def handle_response({:ok, %{status: 200, body: body}}), do: {:ok, body}
  def handle_response({:ok, %{body: body}}), do: {:error, body["status"]["message"]}
  def handle_response({:error, exception}), do: {:error, Exception.message(exception)}
end
