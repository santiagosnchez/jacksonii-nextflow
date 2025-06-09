process get_sra_accessions {
    
    container 'community.wave.seqera.io/library/pandas:2.3.0--4f0f0d6a0c80ada7'
    
    tag "get_sra_accessions"
    
    input:
    path csv_file

    script:
    """
    python -c "
import pandas as pd
df = pd.read_csv('${csv_file}')
for acc in df['Run']:
    print(acc)
" > sra_accessions.txt
    """

    output:
    path 'sra_accessions.txt'

}