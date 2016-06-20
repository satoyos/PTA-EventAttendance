module CsvOutByClassroom
  DATA_HEADER_IN_CLASS =  %w(# 氏名 出欠 参加人数 コース コメント)

  def peer_header(peer)
    peer.classes.map{|cr| [cr.name + '組'] + Array.new(DATA_HEADER_IN_CLASS.size)}.flatten
  end

  def classroom_header(peer)
    peer.classes.map{|cr| DATA_HEADER_IN_CLASS + Array.new(1)}.flatten
  end

  def student_data_of_class(cr, idx: nil, records: [])
    return Array.new(DATA_HEADER_IN_CLASS.size + 1) if (st = cr.students[idx]).nil?
    last_rec = records.select{|rec| rec.correct_student == st}.last
    return  [st.number_in_class, st.name, Array.new(DATA_HEADER_IN_CLASS.size - 1)] if last_rec.nil?
    return [st.number_in_class, st.name, presence_str_for(last_rec), attendee_number_for(last_rec),
            nil, last_rec.comment, nil] unless last_rec.presence
    [st.number_in_class, st.name,
     presence_str_for(last_rec), attendee_number_for(last_rec), st.course, last_rec.comment, nil]
  end

  def classroom_data_of(peer, idx: nil, records: nil)
    peer.classes.map{|cr|
      student_data_of_class(cr, idx: idx, records: records)
    }.flatten
  end

  def csv_str_for_peer(peer, records)
    max_students_num = peer.classes.map{|cr| cr.students.size}.max
    CSV.generate do |csv|
      csv << peer_header(peer)
      csv << classroom_header(peer)
      (0..max_students_num-1).each do |idx|
        csv << classroom_data_of(peer, idx: idx, records: records)
      end
    end
  end

  def csv_out_by_peer(path, peer, records, encoding: 'utf-8')
    File.open(path, 'w:'+encoding) do |outfile|
      outfile.puts csv_str_for_peer(peer, records)
    end
  end
end