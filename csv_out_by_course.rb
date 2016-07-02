module CsvOutByCourse
  DATA_HEADER_IN_COURSE =  %w(クラス # 氏名 参加人数)

  def all_course_header(courses)
    courses.map{|cource_sym| [cource_sym.to_s + 'コース'] + Array.new(DATA_HEADER_IN_COURSE.size)}.flatten
  end

  def header_for_each_course
    DATA_HEADER_IN_COURSE + [nil]
  end

  def student_data(student)
    return Array.new(column_size_per_course) unless student
    [student.class_name, student.number_in_class, student.name, student.attendee_number, nil]
  end

  def csv_str_for_course(fixer)
    students_by_course = fixer.students_to_come.group_by{|st| st.course}
    max_students_num = students_by_course.values.map{|students| students.size}.max
    CSV.generate do |csv|
      csv << all_course_header(students_by_course.keys)
      csv << (header_for_each_course * students_by_course.keys.size)
      (0..max_students_num-1).each do |idx|
        array_at_idx = []
        students_by_course.values.each do |students_in_the_course|
          array_at_idx += student_data(students_in_the_course[idx])
        end
        csv << array_at_idx
      end
    end
  end

  def csv_out_by_course(path, fixer, encoding: 'utf-8')
    File.open(path, 'w:'+encoding) do |outfile|
      outfile.puts csv_str_for_course(fixer)
    end
  end

  private

  def column_size_per_course
    DATA_HEADER_IN_COURSE.size + 1
  end
end