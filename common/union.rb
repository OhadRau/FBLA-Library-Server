# Union favoring a
def union(a, b, by:)
  indices = a.pluck(by) + b.pluck(by)
  indices.uniq.map do |index|
    qry = {}
    qry[by] = index
    a.find_by(qry) || b.find_by(qry)
  end
end
