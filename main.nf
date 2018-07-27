

Channel.from(1,2,3).set{ inch }

process make_files {

    input:
    val(x) from inch

    output:
    set val(x), file("data_${x}.csv") into csv

    script:
    """
    echo "${x},${x},${x}" > data_${x}.csv
    """
}

process to_tsv {

    input:
    set val(x), file(f) from csv

    output:
    file("data_${x}.tsv") into outch

    script:
    """
    sed 's/,/\\t/g' ${f} > data_${x}.tsv
    """
}
