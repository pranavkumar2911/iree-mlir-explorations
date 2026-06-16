import iree.runtime as ireert
import numpy as np

#Setting up iree runtime to use the CPU Backend
config = ireert.Config("local-task")
ctx = ireert.SystemContext(config=config)

#Loading the compiled module
# with open("mips_simple_abs.vmfb", "rb") as f:
#     module_data = f.read()

#Loading the compiled module using mmap (to avoid unaligned buffer)
vm_module = ireert.VmModule.mmap(ctx.instance, "mips_simple_abs.vmfb")
ctx.add_vm_module(vm_module)

#Calling the abs function with a input
input_val = np.array(-3.5, dtype=np.float32)
result = ctx.modules.module.abs(input_val)
print(f"abs(-3.5) = {result.to_host()}")