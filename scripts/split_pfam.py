import os
import gzip
import io

input_file = snakemake.input[0]
output_dir = snakemake.output[0]
desired_entries = snakemake.params.n

n = 0
entry = io.StringIO()
with gzip.open(input_file, 'rt', encoding='latin-1') as file:  # latin-1 is the encoding used by Pfam
    for line in file:
        entry.write(line)
        line = line.strip()

        # Process ID and group
        if line.startswith("#=GF AC   PF"):
            id = line.split()[-1]
            id = id.replace(".", "_")  # Replace dots with underscores to form a valid directory name
        
        # If we have reached the end of an entry
        if line.startswith("//"):

            # Write to file
            dir_group = (int(id[2:7]) - 1) // 100
            output_file = os.path.join(output_dir, str(dir_group), id, id + ".sto")
            os.makedirs(os.path.dirname(output_file), exist_ok=True)
            with open(output_file, "w") as f:
                f.write(entry.getvalue())

            # Reset
            entry = io.StringIO()
            id = None
            n += 1

            # Halt if we have reached the desired number of entries
            if n == desired_entries:
                break
