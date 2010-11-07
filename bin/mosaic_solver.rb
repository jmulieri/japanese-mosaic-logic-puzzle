# mosaic_solver.rb
# author: Jon Mulieri
# date: 11/7/10
class MosaicSolver

public

  # This method solves a Japanese Mosaic Puzzle
  # Input: Puzzle in the following form
  #   [["2", "3", "2"], ["3", "4", "3"], ["2", "3", "2"]]
  # Output: Solved puzzle in the following form
  #   [[" ", "#", " "], ["#", " ", "#"], [" ", "#", " "]]
  def solve(puzzle)
    @puzzle = clone_puzzle(puzzle)
    @puzzle_zero = clone_puzzle(puzzle)
    @solution = clone_puzzle(puzzle)
    dirty_zero_neighbors(@puzzle_zero)
    dirty_zero_neighbors(@solution)
    descend(@solution, 0, 0)
    clear_dirty_cells
    @solution
  end

private

  def cell_satisfied?(row, col)
    @puzzle[row][col].to_i != 0 && count_filled_neighbors(row, col) == @puzzle[row][col].to_i
  end

  def clear_dirty_cells
    @solution.each_index do |row|
      @solution[row].each_index do |col|
        @solution[row][col] = ' ' if @solution[row][col] == '-'
      end
    end
  end

  def clone_puzzle(puzzle)
    new_puzzle = []
    puzzle.each do |row|
      new_puzzle << row.clone
    end
    new_puzzle
  end

  def col_count
    @puzzle[0].count
  end

  def count_filled_neighbors(row, col)
    count = 0
    (row-1..row+1).each do |i|
      (col-1..col+1).each do |j|
        if(i >= 0 && i < @solution.count && j >= 0 && j < @solution[row].count && @solution[i][j] == "#")
          count += 1
        end
      end
    end
    count
  end

  def descend(working_solution, row, col)
    if(row >= row_count || col >= col_count)
      return false
    end

    @solution = clone_puzzle(working_solution)
    fill_in_absolutes

    if(puzzle_solved?)
      return true
    end
    if(puzzle_failed?)
      return false
    end

    next_cell = find_next_cell(row, col)

    if(@solution[row][col] != "#" && @solution[row][col] != "-")
      save_solution = clone_puzzle(@solution)
      @solution[row][col] = "#"
      dirty_absolutes(@solution)
      if(descend(@solution, next_cell[:row], next_cell[:col]))
        return true
      end
      @solution = save_solution
    end

    if(@solution[row][col] != "-")
      @solution[row][col] = " "
    end

    return descend(@solution, next_cell[:row], next_cell[:col])
  end

  def dirty_absolutes(puzzle)
    @puzzle.each_index do |row|
      @puzzle[row].each_index do |col|
        dirty_neighbors(puzzle, row, col) if cell_satisfied?(row, col)
      end
    end
  end

  def dirty_neighbors(puzzle, row, col)
    (row-1..row+1).each do |idx|
      dirty_row(puzzle, idx, col) unless idx < 0 || idx >= row_count
    end
  end

  def dirty_row(puzzle, row, col)
    (col-1..col+1).each do |idx|
      puzzle[row][idx] = '-' unless idx < 0 || idx >= col_count || puzzle[row][idx] == '#'
    end
  end

  def dirty_zero_neighbors(puzzle)
    @puzzle.each_index do |row|
      @puzzle[row].each_index do |col|
        if(@puzzle[row][col] == '0')
          dirty_neighbors(puzzle, row, col)
        end
      end
    end
  end

  def fill_in_absolutes
    @puzzle.each_index do |row|
      @puzzle[row].each_index do |col|
        cells = neighbor_cells(row, col)
        fill_in_cells(cells) if cells.count == @puzzle[row][col].to_i
      end
    end
  end

  def fill_in_cells(cells)
    cells.each do |cell|
      @solution[cell[:row]][cell[:col]] = "#"
    end
  end

  def find_next_cell(row, col)
    col += 1
    if(col >= col_count)
      row += 1
      col = 0
    end
    {:row=>row, :col=>col}
  end

  def neighbor_cells(row, col)
    cells = []
    (row-1..row+1).each do |i|
      (col-1..col+1).each do |j|
        if(i >= 0 && i < row_count && j >= 0 && j < col_count && @solution[i][j] != '-')
          cells << {:row=>i, :col=>j}
        end
      end
    end
    cells
  end

  def puzzle_failed?
    failed = false
    @solution.each_index do |row|
      @solution[row].each_index do |col|
        failed = true if @puzzle_zero[row][col].to_i > 0 && @puzzle_zero[row][col].to_i < count_filled_neighbors(row, col)
      end
    end
    failed
  end

  def puzzle_solved?
    solved = true
    @solution.each_index do |row|
      @solution[row].each_index do |col|
        solved = false if @puzzle_zero[row][col].to_i > 0 && @puzzle_zero[row][col].to_i != count_filled_neighbors(row, col)
      end
    end
    solved
  end

  def row_count
    @puzzle.count
  end

end