module CsvOutByCourse
  def course_header(peer)
    peer.classes.map{|cr| [cr.name + '組'] + Array.new(DATA_HEADER_IN_COURSE.size)}.flatten
  end

  def students_of_course(course_name, peer)
    peer.all_students.select{|st| st.course == course_name}
  end

  def course_data_of(idx=nil)
    raise '何番目のデータを出力するのかを引数で指定してください。' unless idx
    Course.all_courses.map{|course|
      student_data_of_course(course, )

    }
  end

  def csv_str_for_course(fixer)
    students_by_course = fixer.students_to_come.group_by{|st| st.course}
    max_students_num = students_by_course.values.map{|students| students.size}.max
    CSV.generate do |csv|
      #%ToDo: ここをちゃんと書く！
      csv <<  students_by_course.values.map{|students| students.size}
    end
  end

  def csv_out_by_course(path, fixer, encoding: 'utf-8')
    File.open(path, 'w:'+encoding) do |outfile|
      outfile.puts csv_str_for_course(fixer)
    end
  end
end