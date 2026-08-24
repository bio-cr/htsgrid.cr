module SpecFixtures
  extend self

  def with_temp_hts_file(contents : String, &)
    File.tempfile("htsgrid", ".data") do |file|
      file << contents
      file.flush
      yield file.path
    end
  end

  def multisample_vcf : String
    <<-VCF
      ##fileformat=VCFv4.3
      ##contig=<ID=chr1,length=1000>
      ##FILTER=<ID=q10,Description="Quality below 10">
      ##FILTER=<ID=s50,Description="Less than 50 percent samples">
      ##INFO=<ID=DP,Number=1,Type=Integer,Description="Read depth">
      ##INFO=<ID=SOMATIC,Number=0,Type=Flag,Description="Somatic variant">
      ##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">
      ##FORMAT=<ID=DP,Number=1,Type=Integer,Description="Sample depth">
      #CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO	FORMAT	sample1	sample2
      chr1	10	rs1	A	C,G	42.5	q10;s50	DP=12;SOMATIC	GT:DP	0/1:7	1/2:5
      VCF
  end
end
