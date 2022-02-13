
defmodule Gravatar do
  def get_gravatar(email, size \\ 80) do
    email_hash = :crypto.hash(:md5, email) |> Base.encode16(case: :lower)
    "http://www.gravatar.com/avatar/#{email_hash}?d=identicon&s=#{size}"
  end
end
