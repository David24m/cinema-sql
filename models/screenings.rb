require_relative("../db/sql_runner")

class Screening

  attr_reader :id
  attr_accessor :film_times, :availability

  def initialize( options )
    @id = options['id'].to_i
    @film_times = options['film_times']
    @availability = options['availability']
  end

  def save()
    db = PG.connect({ dbname: "cinema", host: "localhost"})
    sql = "INSERT INTO screenings
    (
      film_times,
      availability
    )
    VALUES
    (
      $1, $2
    )
    RETURNING id"
    values = [@film_times, @availability]
    screenings = SqlRunner.run( sql,values ).first
    @id = screenings['id'].to_i
  end

  def Screening.all()
    db = PG.connect({ dbname: "cinema", host: "localhost"})
    sql = "SELECT * FROM screenings"
    values = []
    screenings = SqlRunner.run(sql, values)
    result = screenings.map { |screening| Screening.new (screening)}
    return result
  end

  def Screening.delete_all()
    db = PG.connect({ dbname: "cinema", host: "localhost"})
    sql = "DELETE FROM screenings"
    values = []
    SqlRunner.run(sql, values)
  end

  def delete()
    db = PG.connect({ dbname: "cinema", host: "localhost"})
    sql "DELETE FROM screenings
    WHERE id = $1"
    values = [@id]
    SqlRunner.run(sql, values)
  end

  def update()
    db= PG.connect({ dbname: "cinema", host: "localhost"})
    sql = "UPDATE screenings
    SET (film_times, availability)
    =
    ($1, $2)
    WHERE id = $3
    "
    values = [@film_times, @availability]
    SqlRunner.run(sql, values)
  end



end
