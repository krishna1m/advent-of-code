package day3

import scala.io.Source


val filename = "resources/day3/input"

val allButSymbols: Array[String] = "0123456789.".split("")
val numbersArray: Array[String] = "0123456789".split("")

val lines: Array[Array[String]] = Source.fromFile(filename).getLines.toArray.map(_.toArray.map(_.toString))
val inputCol = lines.length//.debug("The value of inputCol")
val inputRow = lines(0).toArray.length//.debug("The value of inputCol")
val allPositions = for {
  i <- 0 until inputRow
  j <- 0 until inputCol
} yield (i, j)

extension [A](x: A)
  def debug(message: String = ""): A = {
    println(s"$message: $x")
    x
  }

def giveNumberPositionsForPosition(i: Int, j: Int): Set[(Int, Int)] = {
  val startValue: Set[(Int, Int)] = Set((i, j))
  def go(v: Set[(Int, Int)], seeIfChanged: Set[(Int, Int)] = startValue): Set[(Int, Int)] = {
    val next = v.flatMap { 
      case (a, b) => Set((a, b - 1), (a, b + 1)).filter { case (x, y) =>
        !seeIfChanged.contains((x, y))
      }
    }.filter { case (x, y) =>
      (x >= 0) && (x <= inputRow - 1) && (y >= 0) && (y <= inputCol - 1) && (numbersArray.contains(lines(x)(y)))
    }
    val consolidated = next ++ seeIfChanged
    if(consolidated == seeIfChanged) consolidated
    else go(next, consolidated)
  }
  val finalResult = go(startValue)
  finalResult
}

@main
def part1() =
  var possibleNumberPositionsAll = Set.empty[(Int, Int)]
  for(i <- 0 to inputCol - 1) {
    val arrayOfChars: Array[String] = lines(i)
    val charsWithIndex: Array[(String, Int)] = arrayOfChars.zipWithIndex
    val charPositions: List[Int] = charsWithIndex.filter{ case (char, pos) =>
      !allButSymbols.contains(char)
    }.map(_._2).toList
    val possibleNumberPositions: Set[(Int, Int)] = 
      charPositions.flatMap{ j => 
        List((i, j - 1), (i, j + 1), (i - 1, j - 1), (i - 1, j + 1), (i + 1, j - 1), (i + 1, j + 1), (i + 1, j), (i - 1, j))
        .filter { (x :Int, y: Int) =>
          x >= 0 && x <= inputRow - 1 && y >= 0 && y <= inputCol - 1
        }
      }.toSet
    possibleNumberPositionsAll = possibleNumberPositionsAll ++ possibleNumberPositions
  }

  val validPartNumberIndex = allPositions.filter{ case (i, j) => 
    numbersArray.contains(lines(i)(j)) && possibleNumberPositionsAll.contains((i, j))
  }

  val numbersFound = validPartNumberIndex.map { case (i, j) =>
    giveNumberPositionsForPosition(i, j)
    }.toSet.toVector.map {_.toVector.sortWith(_._2 > _._2).map { case (i, j) =>
        lines(i)(j).toInt
      }.zipWithIndex.map { case (number: Int, index: Int) =>
          number * Math.pow(10, index)
      }.sum
    }
    println(numbersFound.sum)

@main
def part2() = {
  // position of star(row, col), position of number(row, col)
  var requiredSum = 0L
  for(i <- 0 to inputCol - 1) {
    val arrayOfChars: Array[String] = lines(i)
    val charsWithIndex: Array[(String, Int)] = arrayOfChars.zipWithIndex
    val charPositions: List[Int] = charsWithIndex.filter{ case (char, pos) =>
      char == "*"
    }.map(_._2).toList//.debug(s"char Positions for row: $i are")
    val possibleNumberPositions: Set[Set[(Int, Int, Int)]] = 
      charPositions.map { j => 
        Set((j, i, j - 1), (j, i, j + 1), (j, i - 1, j - 1), (j, i - 1, j + 1), (j, i + 1, j - 1), (j, i + 1, j + 1), (j, i + 1, j), (j, i - 1, j))
          .filter { (_: Int, x :Int, y: Int) =>
            x >= 0 && x <= inputRow - 1 && y >= 0 && y <= inputCol - 1
          }
      }.toSet//.debug("possibleNumberPositions")
    val validNumberPositions: Set[Set[(Int, Int, Int)]] = possibleNumberPositions.map(inner => inner.filter { case (_, p, q) =>
      numbersArray.contains(lines(p)(q))
    })//.debug("valid number positions")
    val completeNumberPositions = validNumberPositions.map{ set =>
      set.map{ case (col, x, y) =>
        giveNumberPositionsForPosition(x, y)
      }
    }//.debug(s"for asterisk identified at row $i, numbers' location is at")

    completeNumberPositions.foreach { innerSet =>
      if(innerSet.size == 2) {
        val product = innerSet.map(_.toVector.sortWith(_._2 > _._2).map { case (m, n) =>
          lines(m)(n).toInt
          }.zipWithIndex.map { case (number: Int, index: Int) =>
            number * Math.pow(10, index)
          }.sum).product
        requiredSum = requiredSum + product.toLong
      }
    }


  }
  println(s"Final result: $requiredSum")
}
