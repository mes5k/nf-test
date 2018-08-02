

num_files = (int)(params.num_files)
Channel
    .from( 1..num_files )
    .view()
    .set{
        file_create
    }

process create_files {
    input:
    val(num) from file_create

    output:
    file("${num}.txt") into text_files

    script:
    """
    sleep \$(((\$RANDOM % 10)+2))
    echo "${num};${num};${num}" > ${num}.txt
    """
}


process txt_to_csv {
    input:
    file txt from text_files

    output:
    file "${txt}.csv" into csv_files

    script:
    """
    sleep \$(((\$RANDOM % 10)+2))
    sed 's/;/,/g' ${txt} > ${txt}.csv
    """
}

process csv_to_tsv {
    input:
    file csv from csv_files

    output:
    file "${csv}.tsv" into tsv_files

    script:
    """
    sleep \$(((\$RANDOM % 10)+2))
    sed 's/,/\\t/g' ${csv} > ${csv}.tsv
    """
}

process tsv_to_psv {
    input:
    file tsv from tsv_files

    output:
    file "${tsv}.psv" into psv_files

    script:
    """
    sleep \$(((\$RANDOM % 10)+2))
    sed 's/\\t/|/g' ${tsv} > ${tsv}.psv
    """
}

process merge {
    publishDir params.results, mode: 'copy', overwrite: true

    input:
    file '*.psv' from psv_files.toList()

    output:
    file "merge.out" into result

    script:
    """
    cat *.psv > merge.out
    """
}

process test_mount {
    publishDir params.results, mode: 'copy', overwrite: true

    input:
    file(a) from result

    output:
    stdout into fin_res

    script:
    """
    df -h
    cp ${a} /mnt/efs/merge.out
    """
}
