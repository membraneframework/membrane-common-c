defmodule Membrane.Payload.Shm.Native do
  @moduledoc """
  This module provides natively implemented functions allowing low-level
  operations on Posix shared memory. Use with caution!
  """
  alias Membrane.Payload.Shm
  alias Membrane.Type
  use Bundlex.Loader, nif: :membrane_shm_payload

  @doc """
  Creates shared memory segment and a guard for it.

  The guard associated with this memory segment is placed in returned
  `Membrane.Payload.Shm` struct. When the guard resource is deallocated by BEAM,
  the shared memory is unlinked and will disappear from the system when last process
  using it unmaps it
  """
  @spec create(payload :: Shm.t()) :: Type.try_t(Shm.t())
  defnif create(payload)

  @doc """
  Creates guard for existing shared memory.

  This function should be only used when `Membrane.Payload.Shm` struct was created by
  some other NIF and even though the SHM exists, it's guard field is set to `nil`.
  Trying to use it with SHM obtained via `create/1` will result in error.

  See also docs for `create/1`
  """
  @spec add_guard(Shm.t()) :: Type.try_t(Shm.t())
  defnif add_guard(payload)

  @doc """
  Sets the capacity of SHM and updates the struct accordingly
  """
  @spec set_capacity(payload :: Shm.t(), capacity :: pos_integer()) :: Type.try_t()
  defnif set_capacity(payload, capacity)

  @doc """
  Reads the contents of SHM and returns as binary
  """
  @spec read(payload :: Shm.t()) :: Type.try_t(binary())
  def read(%Shm{size: size} = payload) do
    read(payload, size)
  end

  @doc """
  Reads `cnt` bytes from SHM and returns as binary

  `cnt` should not be greater than `payload.size`
  """
  @spec read(payload :: Shm.t(), cnt :: non_neg_integer()) :: Type.try_t(binary())
  defnif read(payload, cnt)

  @doc """
  Writes the binary into the SHM.

  Overwrites existing content. Increases capacity to fit the data.
  """
  @spec write(payload :: Shm.t(), data :: binary()) :: Type.try_t(Shm.t())
  defnif write(payload, data)

  @doc """
  Splits the contents of SHM into 2 by moving part of the data into a new SHM

  `payload` has to be an existing shm (obtained via `create/1`) while `new_payload` has to be
  a struct describing shm that will be created by this function.

  It virtually trims the existing SHM to `position` bytes by setting `size` to `position`
  (The actual data is still present) and the overlapping data is copied into the new SHM.
  """
  @spec split_at(payload :: Shm.t(), new_payload :: Shm.t(), position :: non_neg_integer()) ::
          Type.try_t({Shm.t(), Shm.t()})
  defnif split_at(payload, new_payload, position)
end