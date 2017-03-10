defmodule Anagrams.Repo.Migrations.CreateWords do
  use Ecto.Migration

  def change do
    create table(:words) do
      add :key, :string
      add :word, :string

      timestamps
    end

    create index(:words, [:key])
  end
end
