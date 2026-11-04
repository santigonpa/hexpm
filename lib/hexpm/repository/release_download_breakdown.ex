defmodule Hexpm.Repository.ReleaseDownloadBreakdown do
  use Hexpm.Schema

  @derive {HexpmWeb.Stale, last_modified: nil}
  @primary_key false

  schema "release_download_breakdowns" do
    belongs_to :package, Package, references: :id
    belongs_to :release, Release, references: :id
    field :view, :string
    field :downloads, :integer
  end

  def release(release) do
    from(rd in ReleaseDownloadBreakdown, where: rd.release_id == ^release.id and rd.view == "all")
  end

  def by_period(release_id, :all, false) do
    from(d in ReleaseDownloadBreakdown,
      where: d.release_id == ^release_id and d.view == "all",
      select: %Download{
        package_id: d.package_id,
        release_id: d.release_id,
        downloads: d.downloads
      }
    )
  end

  def by_period(release_id, :all, true) do
    from(d in Download,
      where: d.release_id == ^release_id,
      group_by: [d.package_id, d.release_id],
      select: %Download{
        package_id: d.package_id,
        release_id: d.release_id,
        downloads: sum(d.downloads)
      }
    )
  end

  def by_period(release_id, filter, _date_filtered?) do
    from(d in Download, where: d.release_id == ^release_id)
    |> Download.query_filter(filter)
  end
end
